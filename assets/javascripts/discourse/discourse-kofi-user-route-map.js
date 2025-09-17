export default {
  resource: "user",
  path: "users/:username",
  map() {
    this.route("ko-fi", function () {
      this.route("payments");
      this.route("accounts");
      this.route("claim");
    });
  },
};
