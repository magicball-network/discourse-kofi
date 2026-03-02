export default function () {
  if (this.site.siteSettings.kofi_dashboard_enabled) {
    this.route("ko-fi");
  }
}
