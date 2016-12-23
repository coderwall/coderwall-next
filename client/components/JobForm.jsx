import React, { PropTypes as T } from 'react'
import { reduxForm, Field as FormField } from 'redux-form'

import loadImage from '../lib/loadImage'

const renderInput = ({ input, name, label, placeholder, type, meta: { touched, error } }) => (
  <div>
    <label htmlFor={name}>{label}</label>
    <input
      {...input}
      className={`field block col-12 mb3 ${touched && error && 'is-error'}`}
      type={type}
      placeholder={placeholder} />
  </div>
)
renderInput.propTypes = {
  input: T.object.isRequired,
  label: T.string.isRequired,
  meta: T.object.isRequired,
  name: T.string.isRequired,
  placeholder: T.string.isRequired,
  type: T.string.isRequired,
}

const Field = (props) => (
  <FormField
    component={renderInput}
    type="text"
    {...props} />
)

const RadioField = (props) => (
  <div className="inline-block">
    <FormField
      component="input"
      type="radio"
      value={props.label}
      {...props} />
    <label htmlFor={props.id}>{props.label}</label>
  </div>
)
RadioField.propTypes = { id: T.string, label: T.string }


export const JobForm = ({ handleSubmit, submitting, valid }) => {
  const submitDisabled = submitting || !valid

  return (
    <form onSubmit={handleSubmit}>
      <Field name="title" label="Job Title" placeholder="Sr. Frontend Engineer" />
      <Field name="company" label="Company Name" placeholder="Acme Inc" />
      <Field name="location" label="Location" placeholder="Chicago, Il" />
      <Field name="source" label="Link to your job description" placeholder="https://acme.inc/jobs/78" />
      <Field name="company_url" label="Company Website" placeholder="https://acme.inc" />

      <div className="clearfix mxn2">
        <div className="col col-8 px2">
          <Field name="company_logo" label="Company Logo (optional)" placeholder="https://acme.inc/logo.png" />
        </div>

        <div className="col col-4 px2">
          <FormField
            name="company_logo"
            component={({ input }) => <img
              alt="Company Logo"
              src={input.value}
              style={{ width: 200, height: 200, objectFit: 'cover', float: 'right' }} />} />
        </div>
      </div>

      <Field name="author_name" label="Contact Name" placeholder="Your name" />
      <Field
        name="author_email"
        label="Contact Email" placeholder="Your email for the receipt" type="email" />

      <div className="col-12">
        <RadioField id="role_type_full_time" name="role_type" label="Full Time" />
        <RadioField id="role_type_part_time" name="role_type" label="Part Time" />
        <RadioField id="role_type_contract" name="role_type" label="Contract" />
      </div>

      <div className="center">
        <button
          className={`btn rounded mt3 white px4 py2 ${submitDisabled ? 'bg-gray' : 'bg-green'}`}
          type="submit"
          disabled={submitDisabled}>
          Complete Posting Job for $299
        </button>
      </div>

    </form>
  )
}

JobForm.propTypes = {
  handleSubmit: T.func.isRequired,
  submitting: T.bool.isRequired,
  valid: T.bool.isRequired,
}

const formName = 'job'

const requiredFields = [
  'title',
  'company',
  'location',
  'source',
  'company_url',
  'author_name',
  'author_email',
]

const validate = values =>
  requiredFields.
    filter(k => !values[k]).
    reduce((errs, k) => ({ ...errs, [k]: 'required' }), {})

const asyncValidate = (values) => {
  if (!values.company_logo) { return new Promise(resolve => resolve()) }
  return loadImage(values.company_logo).
    catch(() => {
      throw { company_logo: 'invalid' } // eslint-disable-line no-throw-literal
    })
}
export default reduxForm({
  form: formName,
  initialValues: {
    role_type: 'Full Time',

    // title: 'New Job',
    // company: 'Acme Inc',
    // location: 'Chicago, Il',
    // source: 'https://google.com',
    // company_url: 'https://google.com',
    // author_name: 'Dave',
    // author_email: 'dave@example.com',
  },
  asyncBlurFields: ['company_logo'],
  asyncValidate,
  validate,
})(JobForm)
