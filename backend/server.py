'''
Démarrage de l'application
'''


from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

db = SQLAlchemy()

app_globals = {}


def get_app():
    if app_globals.get('app', False):
        return app_globals['app']
    app = Flask(__name__)
    app.config.from_object('custom_config.CustomConfig')
    db.init_app(app)
    with app.app_context():
        db.create_all()

        from pypnusershub.routes import routes
        app.register_blueprint(routes, url_prefix='/auth')

        from pypnnomenclature.routes import routes
        app.register_blueprint(routes, url_prefix='/nomenclatures')

        from src.core.users.routes import routes
        app.register_blueprint(routes, url_prefix='/users')

        from src.modules.pr_contact.routes import routes
        app.register_blueprint(routes, url_prefix='/contact')

        from src.core.gn_meta.routes import routes
        app.register_blueprint(routes, url_prefix='/meta')

        from src.core.ref_geo.routes import routes
        app.register_blueprint(routes, url_prefix='/geo')

        from src.core.gn_exports.routes import routes
        app.register_blueprint(routes, url_prefix='/exports')

        from src.core.auth.routes import routes
        app.register_blueprint(routes, url_prefix='/auth_cas')

        # errors
        from src.core.errors import routes

        app_globals['app'] = app
    return app


app = get_app()
CORS(app, supports_credentials=True)


if __name__ == '__main__':
    from flask_script import Manager
    Manager(app).run()
