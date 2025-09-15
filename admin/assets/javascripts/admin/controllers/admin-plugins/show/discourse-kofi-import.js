import { tracked } from "@glimmer/tracking";
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

export default class AdminPluginsShowDiscourseKofiImportController extends Controller {
  @service dialog;

  @tracked makePrivate = true;
  @tracked fileSelected = false;

  @tracked saving = false;
  @tracked results = null;
  @tracked success = false;

  resetState() {
    this.saving = false;
    this.results = null;
    this.success = false;
    this.updateFileSelected();
  }

  get importButtonDisabled() {
    return !this.fileSelected || this.saving;
  }

  @action
  updateFileSelected() {
    this.fileSelected = !!document.querySelector("#csvImport")?.files?.length;
  }

  @action
  importPayments() {
    const file = document.querySelector("#csvImport").files[0];
    if (file) {
      const options = {
        type: "POST",
        processData: false,
        contentType: false,
        data: new FormData(),
      };

      options.data.append("file", file);
      options.data.append("make_private", this.makePrivate);

      this.resetState();
      this.saving = true;

      ajax("/ko-fi/admin/payments/import", options)
        .then((result) => {
          this.results = result;
          this.success = result.invalid_rows.length === 0;
        })
        .catch((error) => {
          this.success = false;
          popupAjaxError(error);
        })
        .finally(() => (this.saving = false));
    } else {
      this.dialog.alert(i18n("discourse_kofi.admin.import.aborted"));
    }
  }
}
