import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class UserPayment extends EmberObject {
  static findAll(params) {
    return ajax("/ko-fi/users/payments", {
      method: "get",
      data: params,
    }).then((result) => {
      result.payments = result.payments.map((payment) =>
        UserPayment.create(payment)
      );
      return result;
    });
  }

  hidePayment() {
    return ajax(`/ko-fi/users/payments/${this.id}`, {
      method: "patch",
      dataType: "json",
      data: { is_public: false },
    }).then(() => {
      this.set("is_public", false);
    });
  }
}
