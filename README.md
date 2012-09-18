YSD_MD_RAC
==============

<p>Resource Access Control</p>

<ul>
  <li>permission_owner</li>
  <li>permission_group</li>
  <li>permission_modifier_owner</li>
  <li>permission_modifier_group</li>
  <li>permission_modifier_all</li>
</ul>

<h3>Users::ResourceAccessControlDataMapper</li>

<p>It's a module that can be included in a DataMapper resource to control who can access to the instances.</p>
<p>It will store the owners of the resource and updates any query to be sure that only the users which permission can access the resource.</p>

<h3>Users::ResourceAccessControlPersistence</li>

<p>It's a module that can be included in a Persistence resource to control who can access to the instances.</p>
<p>It will store the owners of the resource and updates any query to be sure that only the users which permission can access the resource.</p>

