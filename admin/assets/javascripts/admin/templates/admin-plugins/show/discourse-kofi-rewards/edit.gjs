import { hash } from "@ember/helper";
import AdminConfigAreaCard from "discourse/admin/components/admin-config-area-card";
import BackButton from "discourse/components/back-button";
import Form from "discourse/components/form";
import ComboBox from "discourse/select-kit/components/combo-box";
import MultiSelect from "discourse/select-kit/components/multi-select";

export default <template>
  <BackButton
    @route="adminPlugins.show.discourse-kofi-rewards"
    @label="discourse_kofi.admin.rewards.title"
  />

  <div class="admin-config-area">
    <div class="admin-config-area__primary-content">
      <AdminConfigAreaCard
        @heading={{@controller.i18nAction "title"}}
        @description={{@controller.i18nAction "description"}}
      >
        <:content>
          <Form
            @validate={{@controller.validateForm}}
            @onSubmit={{@controller.save}}
            @data={{@controller.formData}}
            as |form|
          >
            {{#unless @controller.isSubscription}}
              <form.Field
                @name="badge_id"
                @title={{@controller.i18nField "badge" "title"}}
                @description={{@controller.i18nField "badge" "description"}}
                @format="large"
                as |field|
              >
                <field.Custom>
                  <ComboBox
                    @content={{@controller.badges}}
                    @value={{field.value}}
                    @onChange={{field.set}}
                    @options={{hash clearable=true}}
                  />
                </field.Custom>
              </form.Field>
            {{/unless}}

            <form.Field
              @name="group_id"
              @title={{@controller.i18nField "group" "title"}}
              @description={{@controller.i18nField "group" "description"}}
              @validation={{if @controller.isSubscription "required"}}
              @format="large"
              as |field|
            >
              <field.Custom>
                <ComboBox
                  @content={{@controller.allGroups}}
                  @value={{field.value}}
                  @onChange={{field.set}}
                  @options={{hash clearable=true}}
                />
              </field.Custom>
            </form.Field>

            {{#if @controller.isSubscription}}
              <form.Field
                @name="tier_name"
                @validation="required:trim"
                @title={{@controller.i18nField "tier_name" "title"}}
                @description={{@controller.i18nField "tier_name" "description"}}
                @format="large"
                as |field|
              >
                <field.Input />
              </form.Field>
            {{else}}
              <form.Field
                @name="amount"
                @validation="required|between:0.01,"
                @title={{@controller.i18nField "amount" "title"}}
                @description={{@controller.i18nField "amount" "description"}}
                @format="large"
                as |field|
              >
                <field.Input @type="number" min="0.01" placeholder="0.00" />
              </form.Field>

              <form.Field
                @name="payment_types"
                @validation="required"
                @validate={{@controller.validatePaymentTypes}}
                @title={{@controller.i18nField "payment_types" "title"}}
                @description={{@controller.i18nField
                  "payment_types"
                  "description"
                }}
                @format="large"
                as |field|
              >
                <field.Custom>
                  <MultiSelect
                    @id={{field.id}}
                    @value={{field.value}}
                    @onChange={{field.set}}
                    @content={{@controller.paymentTypes}}
                    @valueProperty={{null}}
                    @nameProperty={{null}}
                    @options={{hash
                      allowAny=false
                      minimum=1
                      useHeaderFilter=true
                    }}
                  />
                </field.Custom>
              </form.Field>
            {{/if}}

            <form.Field
              @name="enabled"
              @validation="required"
              @title={{@controller.i18nField "enabled" "title"}}
              as |field|
            >
              <field.Toggle />
            </form.Field>

            <form.Actions>
              <form.Submit class="save" @label={{this.saveButtonLabel}} />
              <form.Button
                @route="adminPlugins.show.discourse-kofi-rewards"
                @label="cancel_value"
                class="btn-default"
              />
            </form.Actions>
          </Form>
        </:content>
      </AdminConfigAreaCard>
    </div>
  </div>
</template>
