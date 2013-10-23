<li class="${request.getAttribute("attributeClass")!}">
  <div>
    <#if inStock>
      <a class="standardBtn addToCart" href="javascript:submitCheckoutForm(document.${formName!},'ACW','${wishListItem.shoppingListItemSeqId}');" title="Add to Cart">
        <span>${uiLabelMap.OrderAddToCartBtn}</span>
      </a>
    </#if>
  </div>
</li>