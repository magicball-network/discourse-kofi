import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class AdminPluginsDiscourseKofiRewardsEditController extends Controller {
  @service toasts;
  @service router;

  get newReward() {
    return !this.model.id;
  }

  get isSubscription() {
    return this.model.subscription;
  }

  get allGroups() {
    // Show only custom groups
    return this.site.groups.filter(({ id }) => id >= 20);
  }

  get paymentTypes() {
    // TODO: retrieve from server?
    return ["donation", "subscription", "commission", "shop_order"];
  }

  validatePaymentTypes(name, value, { addError }) {
    if (value && value.length === 0) {
      addError(name, {
        title: i18n("discourse_kofi.rewards.payment_types.title"),
        message: i18n("discourse_kofi.rewards.errors.payment_types.missing"),
      });
    }
  }

  get formData() {
    if (this.isSubscription) {
      return {
        subscription: true,
        enabled: this.model.enabled,
        group_id: this.model.group?.id,
        tier_name: this.model.tier_name,
      };
    } else {
      return {
        subscription: false,
        enabled: this.model.enabled,
        badge_id: this.model.badge?.id,
        group_id: this.model.group?.id,
        amount: this.model.amount,
        payment_types: this.model.payment_types,
      };
    }
  }

  @action
  validateForm(data, { addError, removeError }) {
    if (!this.isSubscription) {
      removeError("badge_id");
      removeError("group_id");
      if (!data["badge_id"] && !data["group_id"]) {
        addError("badge_id", {
          title: i18n("discourse_kofi.rewards.badge.title"),
          message: i18n("discourse_kofi.rewards.errors.badge_or_group.missing"),
        });
        addError("group_id", {
          title: i18n("discourse_kofi.rewards.group.title"),
          message: i18n("discourse_kofi.rewards.errors.badge_or_group.missing"),
        });
      }
    }
  }

  @action
  i18nAction(key) {
    let entity = this.isSubscription ? "subscriptions" : "rewards";
    let act = this.newReward ? "create" : "edit";
    return `discourse_kofi.${entity}.actions.${act}.${key}`;
  }

  @action
  i18nField(field, key) {
    let entity = this.isSubscription ? "subscriptions" : "rewards";
    return i18n(`discourse_kofi.${entity}.${field}.${key}`);
  }

  @action
  save(data) {
    this.model
      .persist(data)
      .then(() => {
        this.toasts.success({
          data: {
            message: i18n(this.i18nAction("saved")),
          },
        });
        this.router.transitionTo("adminPlugins.show.discourse-kofi-rewards");
      })
      .catch(popupAjaxError);
  }
}
