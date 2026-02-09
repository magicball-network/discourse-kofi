import Component from "@glimmer/component";
import { hash } from "@ember/helper";
import DButton from "discourse/components/d-button";

export default class GroupRewardUsage extends Component {
  static shouldRender(args, { currentUser }) {
    return currentUser?.admin;
  }

  get usedByReward() {
    return (
      this.args.model.kofi_rewards && this.args.model.kofi_rewards.length > 0
    );
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
