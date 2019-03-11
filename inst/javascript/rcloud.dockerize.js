((function() {

    return {
        init: function(ocaps, k) {

            // Are we in a notebook?
            if (RCloud.UI.navbar.add) {

                oc = RCloud.promisify_paths(ocaps, [
                    [ 'createImage' ]
                ], true);

                RCloud.UI.navbar.add({
                    create_image: {
                        area: 'commands',
                        sort: 3500,
                        modes: ['edit'],
                        create: function() {
                            var control = RCloud.UI.navbar.create_button('create-image', 'Create Image', 'icon-rocket');
                            $(control.control).click(function(e) {
                                oc.createImage(editor.current().notebook);
                            });
                            return control;
                        }
                    }
                });
            }
            k();
        }
    };
})());
