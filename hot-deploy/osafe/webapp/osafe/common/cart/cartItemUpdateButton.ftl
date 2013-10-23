<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.CartItemUpdateBtnCaption}</label>
    <#if !cartLine.getIsPromo()>
      <input type="hidden" name="qtyInCart_${cartLine.getProductId()}" id="js_qtyInCart_${cartLineIndex}"/>
      <a class="standardBtn update" href="javascript:submitCheckoutForm(document.${formName!}, 'UC', '');" title="${uiLabelMap.UpdateBtn}"><span>${uiLabelMap.UpdateBtn}</span></a>
    </#if>
  </div>
</li>