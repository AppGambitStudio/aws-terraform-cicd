module.exports = (sequelize, Sequelize) => {
  const Hello = sequelize.define("hello", {
    title: {
      type: Sequelize.STRING
    },
    description: {
      type: Sequelize.STRING
    }
  });

  return Hello;
};