module.exports = {
  extends: [
    "stylelint-prettier/recommended",
    "stylelint-config-recommended-scss"
  ],

  plugins: ["stylelint-order"],

  rules: {
    "order/properties-alphabetical-order": true
  }
};
