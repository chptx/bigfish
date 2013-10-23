<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.CartItemPriceCaption}</label>
    <span><@ofbizCurrency amount=displayPrice isoCode=currencyUom rounding=globalContext.currencyRounding/></span>
  </div>
</li>
