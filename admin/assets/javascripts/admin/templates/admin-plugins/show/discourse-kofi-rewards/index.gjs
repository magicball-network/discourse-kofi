import { fn } from "@ember/helper";
import RouteTemplate from "ember-route-template";
import { not } from "truth-helpers";
import DButton from "discourse/components/d-button";
import DPageSubheader from "discourse/components/d-page-subheader";
import DropdownMenu from "discourse/components/dropdown-menu";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import DMenu from "float-kit/components/d-menu";

export default RouteTemplate(
  <template>
    <p></p>
    <section class="admin-container discourse-kofi-rewards">
      <DPageSubheader
        @titleLabel={{i18n "discourse_kofi.admin.rewards.title"}}
        @descriptionLabel={{i18n "discourse_kofi.admin.rewards.description"}}
      >
        <:actions as |actions|>
          <actions.Primary
            @label="discourse_kofi.rewards.actions.create.title"
            @route="adminPlugins.show.discourse-kofi-rewards.new"
            @icon="plus"
          />
        </:actions>
      </DPageSubheader>

      {{#if @controller.rewards}}
        <table class="d-admin-table discourse-kofi-rewards-table">
          <thead>
            <tr>
              <th>
                {{i18n "discourse_kofi.rewards.id.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.rewards.enabled.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.rewards.amount.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.rewards.payment_types.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.rewards.badge.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.rewards.group.title"}}
              </th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {{#each @controller.rewards as |reward|}}
              <tr class="d-admin-row__content">
                <td class="d-admin-row__detail">{{reward.id}}</td>
                <td class="d-admin-row__detail">
                  {{#if reward.enabled}}
                    {{icon "circle-check" class="text-successful"}}
                  {{else}}
                    {{icon "circle-xmark" class="text-danger"}}
                  {{/if}}
                </td>
                <td class="d-admin-row__detail">{{reward.amount}}</td>
                <td class="d-admin-row__detail">{{reward.payment_types}}</td>
                <td class="d-admin-row__detail">{{reward.badge.name}}</td>
                <td class="d-admin-row__detail">{{reward.group.name}}</td>
                <td class="d-admin-row__controls">
                  <DButton
                    @icon="pencil"
                    @action={{fn @controller.edit reward}}
                    @label="discourse_kofi.rewards.actions.edit.label"
                    class="btn-default btn-small"
                  />
                  <DMenu
                    @identifier="discourse-kofi-reward-item-menu"
                    @title={{i18n "more_options"}}
                    @icon="ellipsis-vertical"
                    class="btn-default btn-small"
                  >
                    <:content>
                      <DropdownMenu as |dropdown|>
                        <dropdown.item>
                          <DButton
                            @icon="arrows-rotate"
                            @action={{fn @controller.reprocess reward}}
                            @disabled={{not reward.enabled}}
                            @label="discourse_kofi.rewards.actions.reprocess.title"
                            class="btn-default"
                          />
                        </dropdown.item>
                        <dropdown.item>
                          <DButton
                            @icon="trash-can"
                            @action={{fn @controller.delete reward}}
                            @label="discourse_kofi.rewards.actions.delete.title"
                            class="btn-danger"
                          />
                        </dropdown.item>
                      </DropdownMenu>
                    </:content>
                  </DMenu>
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{/if}}
    </section>

    <section class="admin-container discourse-kofi-subscriptions">
      <DPageSubheader
        @titleLabel={{i18n "discourse_kofi.admin.subscriptions.title"}}
        @descriptionLabel={{i18n
          "discourse_kofi.admin.subscriptions.description"
        }}
      >
        <:actions as |actions|>
          <actions.Primary
            @label="discourse_kofi.subscriptions.actions.create.title"
            @route="adminPlugins.show.discourse-kofi-rewards.new-subscription"
            @icon="plus"
          />
        </:actions>
      </DPageSubheader>
      {{#if @controller.subscriptions}}
        <table class="d-admin-table discourse-kofi-subscriptions-table">
          <thead>
            <tr>
              <th>
                {{i18n "discourse_kofi.subscriptions.id.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.subscriptions.enabled.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.subscriptions.tier_name.title"}}
              </th>
              <th>
                {{i18n "discourse_kofi.subscriptions.group.title"}}
              </th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {{#each @controller.subscriptions as |subscription|}}
              <tr>
                <td class="d-admin-row__detail">{{subscription.id}}</td>
                <td class="d-admin-row__detail">
                  {{#if subscription.enabled}}
                    {{icon "circle-check" class="text-successful"}}
                  {{else}}
                    {{icon "circle-xmark" class="text-danger"}}
                  {{/if}}
                </td>
                <td class="d-admin-row__detail">{{subscription.tier_name}}</td>
                <td class="d-admin-row__detail">{{subscription.group.name}}</td>
                <td class="d-admin-row__controls">
                  <DButton
                    @icon="pencil"
                    @action={{fn @controller.edit subscription}}
                    @label="discourse_kofi.subscriptions.actions.edit.label"
                    class="btn-default btn-small"
                  />
                  <DMenu
                    @identifier="discourse-kofi-subscription-item-menu"
                    @title={{i18n "more_options"}}
                    @icon="ellipsis-vertical"
                    class="btn-default btn-small"
                  >
                    <:content>
                      <DropdownMenu as |dropdown|>
                        <dropdown.item>
                          <DButton
                            @icon="arrows-rotate"
                            @action={{fn @controller.reprocess subscription}}
                            @disabled={{not subscription.enabled}}
                            @label="discourse_kofi.subscriptions.actions.reprocess.title"
                            class="btn-default"
                          />
                        </dropdown.item>
                        <dropdown.item>
                          <DButton
                            @icon="trash-can"
                            @action={{fn @controller.delete subscription}}
                            @label="discourse_kofi.subscriptions.actions.delete.title"
                            class="btn-danger"
                          />
                        </dropdown.item>
                      </DropdownMenu>
                    </:content>
                  </DMenu>
                </td>
              </tr>
            {{/each}}
          </tbody>
        </table>
      {{/if}}
    </section>
  </template>
);
