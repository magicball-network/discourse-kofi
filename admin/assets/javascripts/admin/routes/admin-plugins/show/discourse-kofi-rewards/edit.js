import Badge from "discourse/models/badge";
import DiscourseRoute from "discourse/routes/discourse";
import AdminReward from "../../../../models/admin-reward";

export default class AdminPluginsShowDiscourseKofiRewardsEditRoute extends DiscourseRoute {
  async model(params) {
    return await AdminReward.get(params.id);
  }

  setupController(controller, model) {
    controller.setProperties({ model });

    Badge.findAll({ onlyListable: true })
      .then((badges) =>
        badges.map((badge) => {
          // to remove the icons as they do not render well without the colors
          return { id: badge.id, name: badge.name };
        })
      )
      .then((badges) => {
        controller.set("badges", badges);
      });
  }
}
