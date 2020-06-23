begin
	ibs.after_install.grants(null);
	ibs.sviews.create_all_sviews;
    short_views.create_all;
    after_install.recreate_vw_crit('1');
	ibs.after_install.grant_roles(true);
	method_mgr.rebuild_method_interfaces('DEBUGMINIBSO');
end;
/

EXIT

