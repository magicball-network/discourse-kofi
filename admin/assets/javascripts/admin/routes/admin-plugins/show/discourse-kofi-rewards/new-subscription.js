import AdminReward from "../../../../models/admin-reward";
import AdminPluginsShowDiscourseKofiRewardsNewRoute from "./new";

export default class AdminPluginsShowDiscourseKofiRewardsNewSubscriptionRoute extends AdminPluginsShowDiscourseKofiRewardsNewRoute {
  model() {
    return AdminReward.create({ enabled: false, subscription: true });
  }
}
