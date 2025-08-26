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
}
