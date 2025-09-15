import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsShowDiscourseKofiImportRoute extends DiscourseRoute {
  resetController(controller) {
    controller.resetState();
    controller.set("makePrivate", true);
    controller.set("fileSelected", false);
  }
}
