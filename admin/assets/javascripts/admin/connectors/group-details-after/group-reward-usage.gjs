import { tracked } from "@glimmer/tracking";
import Component from "@ember/component";
import { hash } from "@ember/helper";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";

export default class GroupRewardUsage extends Component {
  static shouldRender(args, { currentUser }) {
    return currentUser?.admin;
  }

  @tracked usedByReward = false;

  async init() {
    super.init(...arguments);
    await this.loadUsage();
  }

  async didUpdateAttrs() {
    super.didUpdateAttrs(...arguments);
    await this.loadUsage();
  }

  async loadUsage() {
    if (!this.model) {
      return;
    }
    let rewards = await ajax("/ko-fi/admin/rewards/group-usage", {
      method: "get",
      data: {
        id: this.model.id,
      },
    }).then((result) => result.rewards);
    this.usedByReward = rewards && rewards.length > 0;
  }

  <template>
    {{#if this.usedByReward}}
      <DButton
        @icon="kofi-color"
        @title="discourse_kofi.rewards.warnings.group-usage"
        @route="adminPlugins.show.discourse-kofi-rewards"
        @routeModels={{hash plugin_id="discourse-kofi"}}
      />
    {{/if}}
  </template>
}
