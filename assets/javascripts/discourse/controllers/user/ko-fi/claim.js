import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { extractErrorInfo } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class UserKofiClaimController extends Controller {
  @service dialog;
  @service toasts;
  @service router;

  txid = "";

  @action
  claim() {
    if (!this.txid) {
      return;
    }
    ajax("/ko-fi/users/payments/claim", {
      method: "post",
      data: { reference: this.txid },
    })
      .then((result) => {
        this.toasts.success({
          data: {
            message: i18n("discourse_kofi.user.claim.success"),
          },
        });
        this.router.transitionTo("user.ko-fi.accounts", {
          queryParams: { q: `id:${result.payment.account_id}` },
        });
      })
      .catch((error) => {
        const errorInfo = extractErrorInfo(error);
        this.dialog.alert(
          i18n(`discourse_kofi.user.claim.errors.${errorInfo.message}`)
        );
      });
  }
}
