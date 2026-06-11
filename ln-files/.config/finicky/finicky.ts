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
