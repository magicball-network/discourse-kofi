import Component from "@glimmer/component";

export default class ObscuredEmailAddress extends Component {
  get address() {
    if (this.args.show) {
      return this.args.email;
    } else {
      return this.obscure(this.args.email);
    }
  }

  obscure(email) {
    return email.replace(/(..?)([^@]*)@((..?)(.*)\.)?(.*)/, "$1***@$4***.$6");
  }

  <template>{{this.address}}</template>
}
