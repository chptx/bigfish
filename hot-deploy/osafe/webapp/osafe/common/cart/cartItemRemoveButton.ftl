<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.CartItemRemoveBtnCaption}</label>
    <#if !cartLine.getIsPromo()>
      <a class="standardBtn delete" href="<@ofbizUrl>deleteFromCart?delete_${cartLineIndex}=${cartLineIndex}</@ofbizUrl>" title="${uiLabelMap.RemoveItemBtn}">
        <span>${uiLabelMap.RemoveItemBtn}</span>
      </a>
    </#if>
  </div>
</li>



