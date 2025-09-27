import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsShowDiscourseKofiStatusRoute extends DiscourseRoute {
  async model() {
    return await ajax("/ko-fi/admin/status");
  }

  @action
  async refreshStatus() {
    this.refresh();
  }
}
