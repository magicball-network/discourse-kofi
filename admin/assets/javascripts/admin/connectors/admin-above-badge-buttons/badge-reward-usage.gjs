import Component from "@glimmer/component";
import { hash } from "@ember/helper";
import { LinkTo } from "@ember/routing";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class BadgeRewardUsage extends Component {
  static shouldRender(args, { currentUser }) {
    return currentUser?.admin;
  }

  @service router;
  @service adminBadges;

  get usedByReward() {
    let badge;
    if (this.args.badge) {
      badge = this.args.badge;
    } else {
      // Old version of Discourse did not set the badge argument correctly
      let badgeId = parseInt(this.router.currentRoute?.params["badge_id"], 10);
      badge = this.adminBadges.badges.find((b) => b.id === badgeId);
    }
    return badge && badge.kofi_rewards && badge.kofi_rewards.length > 0;
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
