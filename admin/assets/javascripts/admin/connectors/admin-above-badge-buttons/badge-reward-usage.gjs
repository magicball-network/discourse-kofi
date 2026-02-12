import Component from "@glimmer/component";
import { hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class BadgeRewardUsage extends Component {
  get usedByReward() {
    return (
      this.args.badge.kofi_rewards && this.args.badge.kofi_rewards.length > 0
    );
  }

  <template>
    {{#if this.usedByReward}}
      <div class="alert alert-warning">
        <LinkTo
          @route="adminPlugins.show.discourse-kofi-rewards"
          @model={{hash plugin_id="discourse-kofi"}}
        >
          {{icon "kofi-color"}}
          <span>{{i18n "discourse_kofi.rewards.warnings.badge-usage"}}</span>
        </LinkTo>
      </div>
    {{/if}}
  </template>
}
