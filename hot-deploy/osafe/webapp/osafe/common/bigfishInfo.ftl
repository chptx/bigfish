<#if letestVersionFile?exists && letestVersionFile?has_content>
    <div class="bigfishSiteVersionInformation">
        <div class="displayBox">
            <ul class="displayList">
                <li>
                    <div>
                        <label>${uiLabelMap.LatestVersionFileNameCaption}</label>
                        <span>${letestVersionFile.fileName!}</span>
                    </div>
                </li>
                <li>
                    <div>
                        <label>${uiLabelMap.LatestVersionFileDataCaption}</label>
                        <span>${letestVersionFile.fileData!""}</span>
                    </div>
                </li>
            </ul>
        </div>
    </div>
</#if>