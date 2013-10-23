<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <label>${uiLabelMap.CartItemRemoveBtnCaption}</label>
    <a class="standardBtn delete" href="<@ofbizUrl>${deleteFromWishListAction!}?delete_${wishListItem.shoppingListItemSeqId}=${wishListItem.shoppingListItemSeqId}</@ofbizUrl>" title="${uiLabelMap.RemoveItemBtn}">
      <span>${uiLabelMap.RemoveItemBtn}</span>
    </a>
  </div>
</li>



