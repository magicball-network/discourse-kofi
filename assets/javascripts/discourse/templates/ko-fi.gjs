import Component from "@glimmer/component";
import { htmlSafe } from "@ember/template";
import UserAvatar from "discourse/components/user-avatar";
import icon from "discourse/helpers/d-icon";
import { and } from "discourse/truth-helpers";
import I18n, { i18n } from "discourse-i18n";

export default class extends Component {
  // TODO:
  // #1 = h1 with medium avatar
  // #2,#3 = h2,h3 with small avatar
  // #4... = h4 with tiny avatar

  showBadge(idx) {
    return idx < 3;
  }

  getBadgeType(idx) {
    switch (idx) {
      case 0:
        return "gold";
      case 1:
        return "silver";
      case 2:
        return "bronze";
      default:
        return "";
    }
  }

  formatGoalProgress(goal) {
    if (goal.target) {
      return I18n.messageFormat(
        "discourse_kofi.dashboard.goal.full_format_MF",
        {
          progress: goal.progress,
          target: goal.target,
        }
      );
    } else {
      return I18n.messageFormat(
        "discourse_kofi.dashboard.goal.short_format_MF",
        {
          progress: goal.progress,
        }
      );
    }
  }

  <template>
    <section class="container">
      <div class="contents clearfix body-page kofi_dashboard__main">
        {{htmlSafe @controller.donationMessage.html}}
      </div>
    </section>

    <section class="kofi_dashboard__sections">

      {{#if
        (and
          @controller.siteSettings.kofi_dashboard_widget_enabled
          @controller.siteSettings.kofi_account
        )
      }}
        <div class="kofi_dashboard__widget">
          <iframe
            title="Ko-fi Donation"
            loading="lazy"
            src="https://ko-fi.com/{{@controller.siteSettings.kofi_account}}/?hidefeed=true&widget=true&embed=true&preview=true"
            height="570"
          ></iframe>
        </div>
      {{/if}}

      {{#if @model.goal}}
        <div class="kofi_dashboard__goal">
          <h2>{{i18n "discourse_kofi.dashboard.goal.title"}}</h2>
          <div class="kofi_dashboard__goal_container">
            <div class="kofi_dashboard__goal_container_bar">
              <div
                class="kofi_dashboard__goal_container_bar_progress"
                style={{htmlSafe
                  "--progress-bar-progress: {{@model.goal.progress}}%"
                }}
              ></div>
            </div>
            <div class="kofi_dashboard__goal_container_status">
              {{this.formatGoalProgress @model.goal}}
            </div>
          </div>
        </div>
      {{/if}}

      {{#if @model.leaderboard}}
        <div class="kofi_dashboard__leaderboard">
          <h2>{{i18n "discourse_kofi.dashboard.leaderboard.title"}}</h2>
          {{#each @model.leaderboard as |entry idx|}}
            <div class="badge-card">
              <div class="badge-contents">
                {{#if (this.showBadge idx)}}
                  <span
                    class="badge-icon badge-type-{{this.getBadgeType idx}}"
                    style="--badge-icon-size: var(--font-up-4);"
                    aria-hidden="true"
                  >
                    {{icon "trophy"}}
                  </span>
                {{/if}}
                <div class="badge-info">
                  <div class="badge-info-item">
                    <h3>
                      {{#if entry.user}}
                        <UserAvatar @size="medium" @user={{entry.user}} />
                        {{entry.user.username}}
                      {{else if entry.name}}
                        {{entry.name}}
                      {{else}}
                        Anonymous
                      {{/if}}
                    </h3>
                  </div>
                </div>
              </div>
            </div>
          {{/each}}
        </div>
      {{/if}}

      {{#if @controller.siteSettings.kofi_dashboard_count}}
        <div class="kofi_dashboard__payments">
          This will contain the most recent payments made by users with their
          message and what not.
        </div>
      {{/if}}

    </section>
  </template>
}
