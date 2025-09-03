import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class AdminAccount extends EmberObject {
  static findAll(params) {
    return ajax("/ko-fi/admin/accounts", {
      method: "get",
      data: params,
    }).then((result) => {
      result.accounts = result.accounts.map((account) =>
        AdminAccount.create(account)
      );
      return result;
    });
  }

  toggleAlwaysHide() {
    const newValue = !this.always_hide;
    return ajax(`/ko-fi/admin/accounts/${this.id}`, {
      method: "patch",
      dataType: "json",
      data: { always_hide: newValue },
    }).then(() => {
      this.set("always_hide", newValue);
    });
  }

  hidePayments() {
    return ajax(`/ko-fi/admin/accounts/${this.id}/privatize-payments`, {
      method: "post",
    });
  }

  anonymize() {
    return ajax(`/ko-fi/admin/accounts/${this.id}/anonymize`, {
      method: "post",
    });
  }

  delete() {
    return ajax(`/ko-fi/admin/accounts/${this.id}`, {
      method: "delete",
    });
  }
}
