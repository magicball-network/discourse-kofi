import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsShowDiscourseKofiPaymentsRoute extends DiscourseRoute {
  setupController(controller) {
    controller.resetFilters();
  }
}
