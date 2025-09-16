import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class AdminPluginsShowDiscourseKofiAnonymizeController extends Controller {
  @tracked anonymizeEmail = null;
  @tracked accountId = null;

  @action
  anonymizePayments() {
    if (!this.anonymizeEmail) {
      return;
    }
    ajax("/ko-fi/admin/payments/anonymize", {
      method: "post",
      data: { email: this.anonymizeEmail },
    })
      .then((result) => {
        this.accountId = result.account.id;
      })
      .catch((error) => {
        popupAjaxError(error);
      });
  }
}
