# The Default Content Security Policy (CSP)

When Fossil’s web interface generates an HTML page, it normally includes
a [Content Security Policy][csp] (CSP) in the `<head>`.  The CSP specifies
allowed sources for external resources such as images,
CSS, javascript, and so forth.
The purpose of CSP is to provide an extra layer of protection against
[cross-site scripting][xss] (XSS) and code injection
attacks.  Compatible web browsers will not use external resources unless
they are specifically allowed by the CSP, which dramatically reduces
the attack surface of the application.

Fossil does not rely on CSP for security.
A Fossil server should be secure from attack even without CSP.
Fossil includes built-in server-side content filtering logic.
For example, Fossil purposely breaks `<script>` tags when it finds
them in Markdown and Fossil Wiki documents.  And the Fossil build
process scans the source code for potential injection vulnerabilities
and refuses to compile if any problems are found.
However, CSP provides an additional layer of defense against undetected
bugs that might lead to a vulnerability.

## The Default Restrictions

The default CSP used by Fossil is as follows:

<pre>
     default-src 'self' data:;
     script-src 'self' 'nonce-$nonce';
     style-src 'self' 'unsafe-inline';
     img-src * data:;
</pre>

The default is recommended for most installations.  However,
the site administrators can overwrite this default CSP using the
[default-csp setting](/help?cmd=default-csp).  For example,
CSP restrictions can be completely disabled by setting the default-csp to:

<pre>
     default-src *;
</pre>

The following sections detail the maining of the default CSP setting.

### <a id="base"></a> default-src 'self' data:

This policy means mixed-origin content isn’t allowed, so you can’t refer
to resources on other web domains. Browsers will ignore a link like the
one in the following Markdown under our default CSP:

         ![fancy 3D Fossil logotype](https://i.imgur.com/HalpMgt.png)

If you look in the browser’s developer console, you should see a CSP
error when attempting to render such a page.

The default policy does allow inline `data:` URIs, which means you could
[data-encode][de] your image content and put it inline within the
document:

         ![small inline image](data:image/gif;base64,R0lGODlh...)

That method is best used for fairly small resources. Large `data:` URIs
are hard to read and edit. There are secondary problems as well: if you
put a large image into a Fossil forum post this way, anyone subscribed
to email alerts will get a copy of the raw URI text, which can amount to
pages and pages of [ugly Base64-encoded text][b64].

For inline images within [embedded documentation][ed], it suffices to
store the referred-to files in the repo and then refer to them using
repo-relative URLs:

         ![large inline image](./inlineimage.jpg)

This avoids bloating the doc text with `data:` URI blobs:

There are many other cases, [covered below](#serving).

[b64]: https://en.wikipedia.org/wiki/Base64
[svr]: ./server/


### <a id="img"></a> img-src * data:

As of Fossil 2.15, we don’t restrict the source of inline images at all.
You can pull them in from remote systems as well as pull them from
within the Fossil repository itself, or use `data:` URIs.

If you are certain all images come from only within the repository, you
can close off certain risks — tracking pixels, broken image format
decoders, system dialog box spoofing, etc. — by changing this to
“`img-src 'self'`” possibly followed by “`data:`” if you will also use
`data:` URIs.


### <a id="style"></a> style-src 'self' 'unsafe-inline'

This policy allows CSS information to come from separate files hosted
under the Fossil repo server’s Internet domain. It also allows inline CSS
`<style>` tags within the document text.

The `'unsafe-inline'` declaration allows CSS within individual HTML
elements:

        <p style="margin-left: 4em">Indented text.</p>

As the "`unsafe-`" prefix on the name implies, the `'unsafe-inline'`
feature is suboptimal for security.  However, there are
a few places in the Fossil-generated HTML that benefit from this
flexibility and the work-arounds are verbose and difficult to maintain.
Furthermore, the harm that can be done with style injections is far
less than the harm possible with injected javascript.  And so the
`'unsafe-inline'` compromise is accepted for now, though it might
go away in some future release of Fossil.


### <a id="script"></a> script-src 'self' 'nonce-%s'

This policy disables in-line JavaScript and only allows `<script>`
elements if the `<script>` includes a `nonce` attribute that matches the
one declared by the CSP. That nonce is a large random number, unique for
each HTTP page generated by Fossil, so an attacker cannot guess the
value, so the browser will ignore an attacker’s injected JavaScript.

That nonce can only come from one of three sources, all of which should
be protected at the system administration level on the Fossil server:

*   **Fossil server C code:** All code paths in Fossil that emit
    `<script>` elements include the `nonce` attribute. There are several
    cases, such as the “JavaScript” section of a [custom skin][cs].
    That text is currently inserted into each HTML page generated by
    Fossil,¹ which means it needs to include a `nonce` attribute to
    allow it to run under this default CSP.  We consider JavaScript
    emitted via these paths to be safe because it’s audited by the
    Fossil developers. We assume that you got your Fossil server’s code
    from a trustworthy source and that an attacker cannot replace your
    Fossil server binary.

*   **TH1 code:** The Fossil TH1 interpreter pre-defines the
    [`$nonce` variable](./th1.md#nonce) for use in [custom skins][cs].  For
    example, some of the stock skins that ship with Fossil include a
    wall clock feature up in the corner that updates once a minute.
    These paths are safe in the default Fossil configuration because
    only the [all-powerful Setup user][su] can write TH1 code that
    executes in the server’s running context.

    There is, however, [a default-disabled path](#xss) to beware of,
    covered in the next section.

*   **[CGI server extensions][ext]:** Fossil exports the nonce to the
    CGI in the `FOSSIL_NONCE` environment variable, which it can then
    use in `<script>` elements it generates. Because these extensions
    can only be installed by the Fossil server’s system administrator,
    this path is also considered safe.

[ext]: ./serverext.wiki
[su]:  ./caps/admin-v-setup.md#apsu


#### <a id="xss"></a>Cross-Site Scripting via Ordinary User Capabilities

We’re so restrictive about how we treat JavaScript because it can lead
to difficult-to-avoid scripting attacks. If we used the same CSP for
`<script>` tags [as for `<style>` tags](#style), anyone with check-in
rights on your repository could add a JavaScript file to your repository
and then refer to it from other content added to the site.  Since
JavaScript code can access any data from any URI served under its same
Internet domain, and many Fossil users host multiple Fossil repositories
under a single Internet domain, such a CSP would only be safe if all of
those repositories are trusted equally.

Consider [the Chisel hosting service](http://chiselapp.com/), which
offers free Fossil repository hosting to anyone on the Internet, all
served under the same `http://chiselapp.com/user/$NAME/$REPO` URL
scheme. Any one of those hundreds of repositories could trick you into
visiting their repository home page, set to [an HTML-formatted embedded
doc page][hfed] via Admin → Configuration → Index&nbsp;Page, with this
content:

         <script src="/doc/trunk/bad.js"></script>

That script can then do anything allowed in JavaScript to *any other*
Chisel repository your browser can access. The possibilities for mischief
are *vast*. For just one example, if you have login cookies on four
different Chisel repositories, your attacker could harvest the login
cookies for all of them through this path if we allowed Fossil to serve
JavaScript files under the same CSP policy as we do for CSS files.

This is why the default configuration of Fossil has no way for [embedded
docs][ed], [wiki articles][wiki], [tickets][tkt], [forum posts][fp], or
[tech notes][tn] to automatically insert a nonce into the page content.
This is all user-provided content, which could link to user-provided
JavaScript via check-in rights, effectively giving all such users a
capability that is usually reserved to the repository’s administrator.

The default-disabled [TH1 documents feature][edtf] is the only known
path around this restriction.  If you are serving a Fossil repository
that has any user you do not implicitly trust to a level that you would
willingly run any JavaScript code they’ve provided, blind, you **must
not** give the `--with-th1-docs` option when configuring Fossil, because
that allows substitution of the [pre-defined `$nonce` TH1
variable](./th1.md#nonce) into [HTML-formatted embedded docs][hfed]:

         <script src="/doc/trunk/bad.js" nonce="$nonce"></script>

Even with this feature enabled, you cannot put `<script>` tags into
Fossil Wiki or Markdown-formatted content, because our HTML generators
for those formats purposely strip or disable such tags in the output.
Therefore, if you trust those users with check-in rights to provide
JavaScript but not those allowed to file tickets, append to wiki
articles, etc., you might justify enabling TH1 docs on your repository,
since the only way to create or modify HTML-formatted embedded docs is
through check-ins.

[ed]:   ./embeddeddoc.wiki
[edtf]: ./embeddeddoc.wiki#th1
[hfed]: ./embeddeddoc.wiki#html


## <a id="serving"></a>Serving Files Within the Limits

There are several ways to serve files within the above restrictions,
avoiding the need to [override the default CSP](#override). In
decreasing order of simplicity and preference:

1.  Within [embedded documentation][ed] (only!) you can refer to files
    stored in the repo using document-relative file URLs:

         ![inline image](./inlineimage.jpg)

2.  Relative file URLs don’t work from [wiki articles][wiki],
    [tickets][tkt], [forum posts][fp], or [tech notes][tn], but you can
    still refer to them inside the repo with [`/doc`][du] or
    [`/raw`][ru] URLs:

         ![inline image](/doc/trunk/images/inlineimage.jpg)
         <img src="/raw/logo.png" style="float: right; margin-left: 2em">

3.  Store the files as [unversioned content][uv], referred to using
    [`/uv`][uu] URLs instead:

         ![logo](/uv/logo.png)

4.  Use the [optional CGI server extensions feature](./serverext.wiki)
    to serve such content via `/ext` URLs.

5.  Put Fossil behind a [front-end proxy server][svr] as a virtual
    subdirectory within the site, so that our default CSP’s “self” rules
    match static file routes on that same site. For instance, your repo
    might be at `https://example.com/code`, allowing documents in that
    repo to refer to:

    *   images as `/image/foo.png`
    *   JavaScript files  as `/js/bar.js`
    *   CSS style sheets as `/style/qux.css`

    Although those files are all outside the Fossil repo at `/code`,
    keep in mind that it is the browser’s notion of “self” that matters
    here, not Fossil’s. All resources come from the same Internet
    domain, so the browser cannot distinguish Fossil-provided content
    from static content served directly by the proxy server.

    This method opens up many other potential benefits, such as
    [TLS encryption][tls], high-performance tuning via custom HTTP
    headers, integration with other web technologies like PHP, etc.

You might wonder why we rank in-repo content as most preferred above. It
is because the first two options are the only ones that cause such
resources to be included in an initial clone or in subsequent repo
syncs. The methods further down the list have a number of undesirable
properties:

1.  Relative links to out-of-repo files break in `fossil ui` when run on
    a clone.

2.  Absolute links back to the public repo instance solve that:

        ![inline image](https://example.com/images/logo.png)

    ...but using them breaks some types of failover and load-balancing
    schemes, because it creates a [single point of failure][spof].

3.  Absolute links fail when one’s purpose in using a clone is to
    recover from the loss of a project web site by standing that clone
    up [as a server][svr] elsewhere. You probably forgot to copy such
    external resources in the backup copies, so that when the main repo
    site disappears, so do those files.

Unversioned content is in the middle of the first list above — between
fully-external content and fully in-repo content — because it isn’t
included in a clone unless you give the `--unversioned` flag. If you
then want updates to the unversioned content to be included in syncs,
you have to give the same flag to [a `sync` command](/help?cmd=sync).
There is no equivalent with other commands such as `up` and `pull`, so
you must then remember to give `fossil uv` commands when necessary to
pull new unversioned content down.

Thus our recommendation that you refer to in-repo resources exclusively.

[du]:   /help?cmd=/doc
[fp]:   ./forum.wiki
[ru]:   /help?cmd=/raw
[spof]: https://en.wikipedia.org/wiki/Single_point_of_failure
[tkt]:  ./tickets.wiki
[tn]:   ./event.wiki
[tls]:  ./server/debian/nginx.md 
[uu]:   /help?cmd=/uv
[uv]:   ./unvers.wiki
[wiki]: ./wikitheory.wiki


## <a id="override"></a>Overriding the Default CSP

If you wish to relax the default CSP’s restrictions or to tighten them
further, there are multiple ways to accomplish that.

The following methods are listed in top-down order to give the simplest
and most straightforward method first.  Further methods dig down deeper
into the stack, which is helpful to understand even if you end up using
a higher-level method.


### <a id="cspsetting"></a>The `default-csp` Setting

If the [`default-csp` setting](/help?cmd=default-csp) is defined and is
not an empty string, its value is injected into the page using
[TH1](./th1.md) via one or more of the methods below, depending on the
skin you’re using and local configuration.

Changing this setting is the easiest way to set a nonstandard CSP on
your site.

Because a blank setting tells Fossil to use its hard-coded default CSP,
you have to say something like the following to get a repository without
content security policy restrictions:

        $ fossil set -R /path/to/served/repo.fossil default-csp 'default-src *'

We recommend that instead of using the command line to change this
setting that you do it via the repository’s web interface, in
Admin → Settings.  Write your CSP rules in the edit box marked
"`default-csp`". Do not add hard newlines in that box: the setting needs
to be on a single long line. Beware that changes take effect
immediately, so be careful with your edits: you could end up locking
yourself out of the repository with certain CSP changes!

There are a few reasons why changing this setting via the command line
is inadvisable, except for very short settings like the example above:

1.  You have to be sure to set it on the repository where you want the
    CSP to apply.  Changing this setting on your local clone doesn’t
    affect the remote repo you cloned from, which is most likely where
    you want the CSP restrictions.

2.  For more complicated CSPs, the quoting rules for your shell and the
    CSP syntax may interact, making it difficult or impossible to set
    your desired CSP via the command line.  Setting it via the web UI
    doesn’t have this problem.



### <a id="th1"></a>TH1 Setup Hook

Fossil sets [the TH1 variable `$default_csp`][thvar] from the
`default-csp` setting and uses *that* to inject the value into generated
HTML pages in its stock configuration.

This means that another way you can override this value is to use
the [`th1-setup` hook script](./th1-hooks.md), which runs before TH1
processing happens during skin processing:

        $ fossil set th1-setup "set default_csp {default-src 'self'}"

After [the above](#admin-ui), this is the cleanest method.

[thvar]: ./customskin.md#vars



### <a id="csrc"></a>Fossil C Source Code

When you do neither of the above things, Fossil uses
[a hard-coded default](/info?ln=527-530&name=65a555d0d4fb846b).

We tell you about this not to suggest that you hack the Fossil C source
code to change the CSP but simply to document the next step before we
move down-stack.



### <a id="header"></a>Skin Header

[In the normal case](./customskin.md#override), Fossil injects the CSP
retrieved by one of the above methods into the header of all HTML
documents it generates:

```HTML
<head>...
  <meta http-equiv="Content-Security-Policy" content="...">
  ...
```

Fossil skips this when you’re using a custom skin *and* its
[Header section](./customskin.md#headfoot) includes a `<body>` tag. This
is because prior to Fossil 2.5, the Header for a custom skin normally
contained everything from the opening `<html>` tag through the leading
`<body>` tag. From that version onward, Fossil now generates that header
when possible, so that the skin’s Header normally provides only the
opening tags of the document body, rather than the HTML header.

When we added CSP support in Fossil 2.7, we made use of that mechanism
to inject the CSP into the generated HTML document header.

For backwards compatibility, Fossil skips this when the skin’s Header
includes a `<body>` tag. Fossil takes that as a hint that it’s dealing
with a skin made in the pre-Fossil-2.5 days and doesn’t try to blindly
override it.

The problem then is that you may be a Fossil user from the days before
Fossil 2.5, and you may be using a custom skin. This includes users who
selected one of the stock skins, since for the purposes of this section,
there is no difference between the cases. If you go into Admin → Skins →
Header and find a `<body>` tag, none of the above will apply to your
repo since Fossil will not be injecting its CSP into your pages.

If you selected one of the stock skins (e.g. Khaki) prior to upgrading
to Fossil 2.5+ and didn’t make any changes to it since that time, you
can take the simplest option, which is to simply revert to the stock
version of the skin, so your pages will have the CSP injected, at which
point this document will begin describing what Fossil does with that
repo.

If you’re using a customized version of one of the stock skins, the
skinning mechanism has a diff feature to make it easier to fold your
local changes into the stock version.

If you’re using a fully customized skin, we recommend replicating the
method that [the Bootstrap skin uses][dcinj].² Alone among the stock
Fossil skins, Bootstrap still does old-style Header processing,
providing the entire HTML header and the start of the document body.

We do *not* recommend injecting an explicit `Content-Security-Policy`
meta tag into a header to override Fossil’s default CSP. That means you
have to edit the skin every time you want to change the CSP. Use the TH1
`$default_csp` variable like the Bootstrap skin does so you can use one
of the methods above with your custom skin, so the CSP can vary
independently of the skin.

[dcinj]: /info?ln=7&name=bef080a6929a3e6f


### <a id="fep"></a>Front-End Proxy

If your Fossil repo is behind some sort of HTTP [front-end proxy][svr],
the [preferred method][pmcsp] for setting the CSP is via a custom HTTP
header, which most HTTP reverse proxy programs allow.

Beware that if you have a CSP set via both the HTTP and HTML headers
that the two CSPs [merge](https://stackoverflow.com/a/51153816/142454),
taking the most restrictive elements of each CSP. If you wish the proxy
layer’s setting to completely override Fossil’s setting, you will need
to combine that with one of the methods above to either remove the
Fossil-provided CSP or to make Fossil provide a no-restrictions CSP
which the front-end proxy can then tighten down.

[pmcsp]: https://developers.google.com/web/fundamentals/security/csp/#the_meta_tag



------------


**Asides and Digressions:**

1.  Fossil might someday switch to serving the “JavaScript” section of a
    custom skin as a virtual text file, allowing it to be cached by the
    browser, reducing page load times.

2.  The stock Bootstrap skin *did* provide redundant CSP text from
    Fossil 2.7 through Fossil 2.9, so setting the CSP via the higher
    level methods did not work with that skin. We fixed this in Fossil
    2.10, but if you selected the Bootstrap skin prior to that, you’re
    now running on a *copy* of it stored in your repo settings table, so
    the change to the stock version of the skin won’t affect that repo
    automatically. You will have to either merge the diffs in with your
    local changes or revert to the stock version of the skin.


[cs]:    ./customskin.md
[csp]:   https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
[de]:    https://dopiaza.org/tools/datauri/index.php
[xss]:   https://en.wikipedia.org/wiki/Cross-site_scripting