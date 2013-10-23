<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.CartItemQuantityCaption}</label>
    <input size="6" type="text" name="update_${wishListSeqId}" id="update_${rowNo}" value="${quantity!}" maxlength="5"/>
  </div>
</li>
