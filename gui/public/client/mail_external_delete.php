<?php
/**
 * i-MSCP - internet Multi Server Control Panel
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * @category    iMSCP
 * @package     iMSCP_Core
 * @subpackage  Client
 * @copyright   2010-2013 by i-MSCP team
 * @author      Laurent Declercq <l.declercq@nuxwin.com>
 * @author      iMSCP Team
 * @link        http://www.i-mscp.net i-MSCP Home Site
 * @license     http://www.gnu.org/licenses/gpl-2.0.txt GPL v2
 */

/***********************************************************************************************************************
 * Functions
 */

/**
 * Delete one or many external mail server related entries
 *
 * @throws iMSCP_Exception_Database
 * @param array $items Item(s) to delete
 * @param bool $postRequest Flag indicating whether POST data were received
 * @return void
 */
function client_deleteExternalMailServers($items, $postRequest)
{
    if (isset($items['normal']) || isset($items['alias'])) {
        /** @var $cfg iMSCP_Config_Handler_File */
        $cfg = iMSCP_Registry::get('config');
        $domainId = get_user_domain_id($_SESSION['user_id']);

        /** @var $db iMSCP_Database */
        $db = iMSCP_Registry::get('db');
        $db->beginTransaction();

        try {
            $numberDeletedEntries = 0;

            if (!empty($items['normal'])) {
                $itemId = array_shift($items['normal']);

                if ($itemId === $domainId) {
                    $query = 'SELECT `external_mail_dns_ids` FROM `domain` WHERE `domain_id` = ?';
                    $stmt = exec_query($query, $domainId);

                    if ($stmt->rowCount() && $stmt->fields['external_mail_dns_ids'] != '') {
                        $query = '
                            DELETE FROM
                                `domain_dns`
                            WHERE
                                `domain_dns_id` IN(' . $stmt->fields['external_mail_dns_ids'] . ')
                        ';
                        exec_query($query);

                        $query = '
                          UPDATE
                            `domain`
                          SET
                            `external_mail` = ?, `domain_status` = ?, `external_mail_dns_ids` = ?
                          WHERE
                            `domain_id` = ?
					    ';
                        exec_query($query, array('off', $cfg->ITEM_TOCHANGE_STATUS, null, $itemId));

                        $numberDeletedEntries++;
                    }
                }
            }

            if (!empty($items['alias'])) {
                foreach ((array)$items['alias'] as $itemId) {
                    $query = '
                      SELECT
                        `alias_name`, `external_mail_dns_ids`
                      FROM
                        `domain_aliasses`
                      WHERE
                        `alias_id` = ?
                      AND
                        `domain_id` = ?
                    ';
                    $stmt = exec_query($query, array($itemId, $domainId));

                    if ($stmt->rowCount() && $stmt->fields['external_mail_dns_ids'] != '') {
                        $query = '
                            DELETE FROM
                                `domain_dns`
                            WHERE
                                `domain_dns_id` IN(' . $stmt->fields['external_mail_dns_ids'] . ')
                        ';
                        exec_query($query);

                        $query = '
                          UPDATE
                            `domain_aliasses`
                          SET
                            `external_mail` = ?, `alias_status` = ?, `external_mail_dns_ids` = ?
                          WHERE
                            `alias_id` = ?
                          AND
                            `domain_id` = ?
    					';
                        exec_query($query, array('off', $cfg->ITEM_TOCHANGE_STATUS, null, $itemId, $domainId));

                        $numberDeletedEntries++;
                    }
                }
            }

            $db->commit();
            send_request(); // Ask the daemon to trigger the backend dispatcher

            if ($numberDeletedEntries > 0) {
                set_page_message(tr('External mail server entries successfully scheduled for deletion.'), 'success');
            } else {
                set_page_message(tr('Nothing has been scheduled for deletion.'), 'error');
            }
        } catch (iMSCP_Exception_Database $e) {
            $db->rollBack();
            throw new iMSCP_Exception_Database($e->getMessage(), $e->getQuery(), $e->getCode(), $e);
        }
    } else {
        if ($postRequest) {
            set_page_message(tr('You must select a least one item to deactivate.'), 'warning');
        } else {
			showBadRequestErrorPage();
        }
    }
}

/***********************************************************************************************************************
 * Main
 */

// Include core library
require_once 'imscp-lib.php';

iMSCP_Events_Manager::getInstance()->dispatch(iMSCP_Events::onClientScriptStart);

check_login('user');

// If the feature is disabled, redirects in silent way
if (customerHasFeature('external_mail')) {
    if (!empty($_POST)) {
        $items['normal'] = (isset($_POST['normal'])) ? $_POST['normal'] : null;
        $items['alias'] = (isset($_POST['alias'])) ? $_POST['alias'] : null;
        $postRequest = true;
    } else if (isset($_GET['item']) && count($item = explode(';', $_GET['item'], 2)) == 2) {
        $items[$item[1]][] = $item[0];
        $postRequest = false;
    } else {
		showBadRequestErrorPage();
    }

    client_deleteExternalMailServers($items, $postRequest);
    redirectTo('mail_external.php');
} else {
	showBadRequestErrorPage();
}

redirectTo('index.php');
