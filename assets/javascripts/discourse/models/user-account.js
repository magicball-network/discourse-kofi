import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class UserAccount extends EmberObject {
  static findAll(params) {
    return ajax("/ko-fi/users/accounts", {
      method: "get",
      data: params,
    }).then((result) => {
      result.accounts = result.accounts.map((account) =>
        UserAccount.create(account)
      );
      return result;
    });
  }

  toggleAlwaysHide() {
    const newValue = !this.always_hide;
    return ajax(`/ko-fi/users/accounts/${this.id}`, {
      method: "patch",
      dataType: "json",
      data: { always_hide: newValue },
    }).then(() => {
      this.set("always_hide", newValue);
    });
  }

  hidePayments() {
    return ajax(`/ko-fi/users/accounts/${this.id}/privatize-payments`, {
      method: "post",
    });
  }
}
