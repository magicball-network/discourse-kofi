import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsShowDiscourseKofiAccountsRoute extends DiscourseRoute {
  setupController(controller) {
    controller.resetFilters();
    controller.emailsVisible = false;
  }
}
