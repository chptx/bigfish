<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.AdjustedTotalCaption}</label>
    <span><@ofbizCurrency amount=orderGrandTotal! isoCode=currencyUom  rounding=globalContext.currencyRounding/></span>
  </div>
</li>