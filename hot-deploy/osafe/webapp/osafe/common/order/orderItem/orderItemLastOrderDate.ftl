<li class="${request.getAttribute("attributeClass")!}">
    <div>
      <label>${uiLabelMap.LastOrderDateCaption}</label>
      <span>${(Static["com.osafe.util.Util"].convertDateTimeFormat(orderDate, preferredDateFormat))!"N/A"}</span>
    </div>
</li>