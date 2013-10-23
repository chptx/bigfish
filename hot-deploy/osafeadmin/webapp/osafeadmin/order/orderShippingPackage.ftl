<div class="boxBody">
    <div class="heading">${orderShippingPackageInfoHeading!}</div>
    <#assign dimensionUom = delegator.findByPrimaryKey('Uom', {"uomId" : shipmentPackage.dimensionUomId!})!"" />
    <#assign weightUom = delegator.findByPrimaryKey('Uom', {"uomId" : shipmentPackage.weightUomId!})!"" />
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.HeightCaption}</label>
            </div>
            <div class="infoValue">
                <#if shipmentPackage?has_content>
                    ${shipmentPackage.boxHeight!}
                    <#if shipmentPackage.boxHeight?has_content && dimensionUom?has_content>
                        ${dimensionUom.abbreviation!}
                    </#if>
                </#if>
                 
            </div>
        </div>
    </div>
    
    <div class="infoRow column">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.WeightCaption}</label>
            </div>
            <div class="infoValue">
                <#if shipmentPackage?has_content>
                    ${shipmentPackage.weight!}
                    <#if shipmentPackage.weight?has_content && weightUom?has_content>
                        ${weightUom.abbreviation!}
                    </#if>
                </#if>
            </div>
        </div>
    </div>
    
    <div class="infoRow row">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.WidthCaption}</label>
            </div>
            <div class="infoValue">
                <#if shipmentPackage?has_content>
                    ${shipmentPackage.boxWidth!}
                    <#if shipmentPackage.boxWidth?has_content && dimensionUom?has_content>
                        ${dimensionUom.abbreviation!}
                    </#if>
                </#if>
            </div>
        </div>
    </div>
    
    <div class="infoRow row">
        <div class="infoEntry">
            <div class="infoCaption">
                <label>${uiLabelMap.DepthCaption}</label>
            </div>
            <div class="infoValue">
                <#if shipmentPackage?has_content>
                    ${shipmentPackage.boxLength!}
                    <#if shipmentPackage.boxLength?has_content && dimensionUom?has_content>
                        ${dimensionUom.abbreviation!}
                    </#if>
                </#if>
            </div>
        </div>
    </div>
</div>

