import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "discourse-kofi-admin-plugin-configuration-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser || !currentUser.admin) {
      return;
    }

    withPluginApi((api) => {
      api.setAdminPluginIcon("discourse-kofi", "kofi");

      api.addAdminPluginConfigurationNav("discourse-kofi", [
        {
          label: "discourse_kofi.admin.status.title",
          route: "adminPlugins.show.discourse-kofi-status",
          description: "discourse_kofi.admin.status.description",
        },
        {
          label: "discourse_kofi.admin.payments.title",
          route: "adminPlugins.show.discourse-kofi-payments",
          description: "discourse_kofi.admin.payments.description",
        },
        {
          label: "discourse_kofi.admin.rewards-management.title",
          route: "adminPlugins.show.discourse-kofi-rewards",
          description: "discourse_kofi.admin.rewards-management.description",
        },
        {
          label: "discourse_kofi.admin.accounts.title",
          route: "adminPlugins.show.discourse-kofi-accounts",
          description: "discourse_kofi.admin.accounts.description",
        },
        {
          label: "discourse_kofi.admin.import.title",
          route: "adminPlugins.show.discourse-kofi-import",
          description: "discourse_kofi.admin.import.description",
        },
        {
          label: "discourse_kofi.admin.anonymize.title",
          route: "adminPlugins.show.discourse-kofi-anonymize",
          description: "discourse_kofi.admin.anonymize.description",
        },
      ]);
    });
  },
};
