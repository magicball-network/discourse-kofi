export default function () {
  let enabled =
    this.site.siteSettings.kofi_dashboard_enabled === "enabled" ||
    (this.site.siteSettings.kofi_dashboard_enabled === "authenticated_only" &&
      this.site.currentUser);
  if (enabled) {
    this.route("ko-fi");
  }
}
