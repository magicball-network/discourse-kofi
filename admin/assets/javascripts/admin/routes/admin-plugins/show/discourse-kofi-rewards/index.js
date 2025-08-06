import { action } from "@ember/object";
import DiscourseRoute from "discourse/routes/discourse";
import AdminReward from "../../../../../admin/models/admin-reward";

export default class AdminPluginsShowDiscourseKofiRewardsRoute extends DiscourseRoute {
  async model() {
    return await AdminReward.getAll();
  }

  @action
  reloadModel() {
    this.refresh();
  }

  setupController(controller, model) {
    controller.setProperties({ model });
  }
}
