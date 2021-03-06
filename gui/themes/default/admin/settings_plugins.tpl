
<script type="text/javascript">
	/* <![CDATA[ */
	$(document).ready(function () {
		$('.datatable').dataTable({ "oLanguage": {DATATABLE_TRANSLATIONS}, "iDisplayLength": 5 });

		$("#dialog_box").dialog(
			{
				modal: true,
				autoOpen: false,
				hide: "blind",
				show: "blind",
				width: 650
			}
		);

		$(".i_change_password").click(function (e) {
			e.preventDefault();
			var href = $(this).attr("href");

			$("#dialog_box").dialog("option", "buttons", {
				"{TR_PROTECT}": function () { window.location.href = href; },
				"{TR_CANCEL}": function () { $(this).dialog("close"); }
			});

			$("#dialog_box").dialog("open");
		});

		$('#bulkActionsTop, #bulkActionsBottom').change(function () {
			$('select[name="bulkActions"] option[value=' + $(this).val() + ']').attr("selected", "selected");
		});

		$("thead :checkbox, tfoot :checkbox").change(
			function ($e) { $("table :checkbox").prop('checked', $(this).is(':checked')); }
		);

		$('button[name=updatePluginList]').click(function () { document.location = "?updatePluginList=all"; });

		$(".plugin_error").click(function (e) {
			var errDialog = $('<div>' + '<pre>' + $.trim($(this).html()) + '</pre>' + '</div>');
			var pluginName = $(this).attr('id');

			errDialog.dialog(
				{
					modal: true,
					title: pluginName + " - {TR_ERROR_DETAILS}",
					show: "clip",
					hide: "clip",
					minHeight: 200,
					minWidth: 500,
					buttons: [
						{ text: "{TR_FORCE_RETRY}", click: function () {
							window.location = "?retry=" + pluginName
						} },
						{ text: "{TR_CLOSE}", click: function () {
							$(this).dialog("close").dialog("destroy")
						} }
					]
				}
			);

			return false;
		});
	});
	/*]]>*/
</script>
<!-- BDP: plugins_block -->

<p class="hint" style="font-variant: small-caps;font-size: small;">{TR_PLUGIN_HINT}</p>

<br/>

<div id="dialog_box" title="{TR_PLUGIN_CONFIRMATION_TITLE}">
	<p>{TR_PROTECT_CONFIRMATION}</p>
</div>

<form name="pluginsFrm" action="settings_plugins.php" method="post">
	<table class="datatable">
		<thead>
		<tr style="border: none;">
			<th style="width:21px;"><label><input type="checkbox"/></label></th>
			<th style="width:150px">{TR_PLUGIN}</th>
			<th>{TR_DESCRIPTION}</th>
			<th>{TR_STATUS}</th>
			<th>{TR_ACTIONS}</th>
		</tr>
		</thead>
		<tfoot>
		<tr>
			<td><label><input type="checkbox"/></label></td>
			<td>{TR_PLUGIN}</td>
			<td>{TR_DESCRIPTION}</td>
			<td>{TR_STATUS}</td>
			<td>{TR_ACTIONS}</td>
		</tr>
		</tfoot>
		<tbody>
		<!-- BDP: plugin_block -->
		<tr>
			<td><label><input type='checkbox' name='checked[]' value="{PLUGIN_NAME}"/></label></td>
			<td><p><strong>{PLUGIN_NAME}</strong></p></td>
			<td>
				<p>{PLUGIN_DESCRIPTION}</p>
				<span class="bold italic">
					<small>{TR_VERSION} {PLUGIN_VERSION} | <a href="mailto:{PLUGIN_MAILTO}">{TR_BY} {PLUGIN_AUTHOR}</a>
						| <a href="{PLUGIN_SITE}" target="_blank">{TR_VISIT_PLUGIN_SITE}</a></small>
				</span>
			</td>
			<td>
				{PLUGIN_STATUS}
				<!-- BDP: plugin_status_details_block -->
				<span id="{PLUGIN_NAME}" style="vertical-align: middle" class="plugin_error icon i_help"
					  title="{TR_CLICK_FOR_MORE_DETAILS}">
					{PLUGIN_STATUS_DETAILS}
				</span>
				<!-- EDP: plugin_status_details_block -->
			</td>
			<td>
				<!-- BDP: plugin_activate_link -->
				<a style="vertical-align: middle" class="icon i_open" href="settings_plugins.php?activate={PLUGIN_NAME}"
				   title="{TR_ACTIVATE_TOOLTIP}"></a>
				<a style="vertical-align: middle" class="icon i_close" href="settings_plugins.php?delete={PLUGIN_NAME}"
				   title="{TR_DELETE_TOOLTIP}"></a>
				<!-- EDP: plugin_activate_link -->
				<!-- BDP: plugin_deactivate_link -->
				<a style="vertical-align: middle" class="icon i_close"
				   href="settings_plugins.php?deactivate={PLUGIN_NAME}" title="{TR_DEACTIVATE_TOOLTIP}"></a>
				<a style="vertical-align: middle" class="icon i_change_password"
				   href="settings_plugins.php?protect={PLUGIN_NAME}" title="{TR_PROTECT_TOOLTIP}"></a>
				<!-- EDP: plugin_deactivate_link -->
			</td>
		</tr>
		<!-- EDP: plugin_block -->
		</tbody>
	</table>
	<div style="float:left;">
		<select name="bulkActions" id="bulkActionsBottom">
			<option value="dummy">{TR_BULK_ACTIONS}</option>
			<option value="activate">{TR_ACTIVATE}</option>
			<option value="deactivate">{TR_DEACTIVATE}</option>
			<option value="protect">{TR_PROTECT}</option>
			<option value="delete">{TR_DELETE}</option>
		</select>
		<label for="bulkActionsBottom"><input type="submit" name="Submit" value="{TR_APPLY}"/></label>
	</div>
</form>
<!-- EDP: plugins_block -->

<div class="buttons">
	<button type="button" name="updatePluginList">{TR_UPDATE_PLUGIN_LIST}</button>
</div>

<br/>

<h2 class="plugin"><span>{TR_PLUGIN_UPLOAD}</span></h2>

<form name="pluginsUploadFrm" action="settings_plugins.php" method="post" enctype="multipart/form-data">
	<table class="firstColFixed">
		<thead>
		<tr>
			<th colspan="2">{TR_UPLOAD}</th>
		</tr>
		</thead>
		<tbody>
		<tr>
			<td>
				{TR_PLUGIN_ARCHIVE}
				<span class="upload_help icon i_help" title="{TR_PLUGIN_ARCHIVE_TOOLTIP}"></span>
			</td>
			<td>
				<input type="file" name="pluginArchive"/>
				<input type="submit" value="{TR_UPLOAD}"/>
			</td>
		</tr>
		</tbody>
	</table>
</form>
