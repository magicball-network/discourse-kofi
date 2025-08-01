export default {
  resource: "admin.adminPlugins.show",
  path: "/plugins",
  map() {
    this.route("discourse-kofi-payments", { path: "payments" });
    this.route("discourse-kofi-rewards", { path: "rewards" }, function () {
      this.route("new");
      this.route("new-subscription");
      this.route("edit", { path: ":id" });
    });
    this.route("discourse-kofi-accounts", { path: "accounts" });
    this.route("discourse-kofi-import", { path: "import" });
    this.route("discourse-kofi-anonymize", { path: "anonymize" });
  },
};
