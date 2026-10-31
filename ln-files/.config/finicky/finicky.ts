module.exports = {
  defaultBrowser: "Safari",
  rewrite: [
    {
      match: "x.com/*",
      url: (url) => {
        url.host = "xcancel.com";
        return url;
      },
    },
  ],
  handlers: [
    {
      match: url => url.hostname === "slides.google.com" ||
        (url.hostname === "docs.google.com" && /^\/presentation(?:\/|$)/.test(url.pathname)),
      browser: "Google Chrome"
    },
    {
      match: finicky.matchHostnames(["localhost"]),
      browser: "Google Chrome"
    },
    {
      match: finicky.matchHostnames(["meet.google.com"]),
      browser: "Google Chrome"
    },
		{
			match: finicky.matchHostnames(["accounts.google.com"]),
			browser: "Google Chrome"
		},
		{
			match: finicky.matchHostnames(["https://claude.ai/oauth/authoriz"]),
			browser: "Google Chrome"
		}
  ]
}
