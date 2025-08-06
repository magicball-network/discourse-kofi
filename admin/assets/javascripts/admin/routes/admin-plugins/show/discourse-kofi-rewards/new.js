import AdminReward from "../../../../models/admin-reward";
import AdminPluginsShowDiscourseKofiRewardsEditRoute from "./edit";

export default class AdminPluginsShowDiscourseKofiRewardsNewRoute extends AdminPluginsShowDiscourseKofiRewardsEditRoute {
  templateName = "admin-plugins/show/discourse-kofi-rewards/edit";
  controllerName = "admin-plugins/show/discourse-kofi-rewards/edit";

  model() {
    return AdminReward.create({
      enabled: false,
      subscription: false,
      payment_types: ["donation"],
    });
  }
}
