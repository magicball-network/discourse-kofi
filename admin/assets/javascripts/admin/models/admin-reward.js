import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class AdminReward extends EmberObject {
  static getAll() {
    return ajax("/ko-fi/admin/rewards", {
      method: "get",
    }).then((result) => {
      return {
        rewards: result.rewards.map((reward) => AdminReward.create(reward)),
        subscriptions: result.subscriptions.map((reward) =>
          AdminReward.create(reward)
        ),
      };
    });
  }

  static get(id) {
    return ajax(`/ko-fi/admin/rewards/${id}`, {
      method: "get",
    }).then((result) => AdminReward.create(result.reward));
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
