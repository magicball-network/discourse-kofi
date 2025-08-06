import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class AdminPluginsDiscourseKofiRewardsController extends Controller {
  @service router;
  @service dialog;
  @service toasts;

  get rewards() {
    return this.model.rewards;
  }

  get subscriptions() {
    return this.model.subscriptions;
  }

  @action
  edit(reward) {
    this.router.transitionTo(
      "adminPlugins.show.discourse-kofi-rewards.edit",
      reward.id
    );
  }

  @action
  reprocess(reward) {
    const rewardType = reward.subscription ? "subscriptions" : "rewards";
    const performReprocess = () => {
      reward
        .reprocess()
        .then(() => {
          this.toasts.success({
            data: {
              message: i18n(
                `discourse_kofi.${rewardType}.actions.reprocess.started`,
                reward
              ),
            },
          });
        })
        .catch(popupAjaxError);
    };

    this.dialog.confirm({
      title: i18n(`discourse_kofi.${rewardType}.actions.reprocess.title`),
      message: i18n(
        `discourse_kofi.${rewardType}.actions.reprocess.confirmation`,
        reward
      ),
      confirmButtonIcon: "arrows-rotate",
      confirmButtonLabel: `discourse_kofi.${rewardType}.actions.reprocess.confirm`,
      didConfirm: performReprocess,
    });
  }

  @action
  delete(reward) {
    const rewardType = reward.subscription ? "subscriptions" : "rewards";
    const performDelete = () => {
      reward
        .delete()
        .then(() => {
          this.toasts.success({
            data: {
              message: i18n(
                `discourse_kofi.${rewardType}.actions.delete.deleted`,
                reward
              ),
            },
          });
          this.send("reloadModel");
        })
        .catch(popupAjaxError);
    };

    this.dialog.confirm({
      title: i18n(`discourse_kofi.${rewardType}.actions.delete.title`),
      message: i18n(
        `discourse_kofi.${rewardType}.actions.delete.confirmation`,
        reward
      ),
      confirmButtonIcon: "trash-can",
      confirmButtonLabel: `discourse_kofi.${rewardType}.actions.delete.confirm`,
      confirmButtonClass: "btn-danger",
      didConfirm: performDelete,
    });
  }
}
