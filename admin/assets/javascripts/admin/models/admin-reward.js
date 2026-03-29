import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

class AdminRewardBadge extends EmberObject {
  get badgeTypeClassName() {
    return `badge-type-${this.badge_type_name}`;
  }
}

export default class AdminReward extends EmberObject {
  static getAll() {
    return ajax("/ko-fi/admin/rewards", {
      method: "get",
    }).then((result) => {
      return {
        rewards: result.rewards.map((reward) =>
          AdminReward.createModel(reward)
        ),
        subscriptions: result.subscriptions.map((reward) =>
          AdminReward.createModel(reward)
        ),
      };
    });
  }

  static get(id) {
    return ajax(`/ko-fi/admin/rewards/${id}`, {
      method: "get",
    }).then((result) => AdminReward.createModel(result.reward));
  }

  static createModel(data) {
    let result = AdminReward.create(data);
    if (data.badge) {
      result.badge = AdminRewardBadge.create(data.badge);
    }
    return result;
  }

  get payment_types_list() {
    return this.payment_types.join(", ");
  }

  persist(data) {
    let result;
    if (this.id) {
      result = ajax(`/ko-fi/admin/rewards/${this.id}`, {
        method: "put",
        data,
      });
    } else {
      result = ajax(`/ko-fi/admin/rewards`, {
        method: "post",
        data,
      });
    }
    return result.then((body) => AdminReward.create(body.reward));
  }

  reprocess() {
    return ajax(`/ko-fi/admin/rewards/${this.id}/reprocess`, {
      method: "post",
    });
  }

  delete() {
    return ajax(`/ko-fi/admin/rewards/${this.id}`, {
      method: "delete",
    });
  }
}
